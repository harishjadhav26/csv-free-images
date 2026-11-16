#!/usr/bin/env bash
# patch-fatjar.sh <fatjar> <fixed-artifacts-dir>
# Replaces vulnerable nested jars inside a Spring Boot fat jar (BOOT-INF/lib)
# with fixed versions, AND updates BOOT-INF/classpath.idx so the classpath
# index points at the new jar names.
set -euo pipefail

FATJAR="$(realpath "$1")"
FIXED="$(realpath "$2")"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[patch] Reading nested jars from $FATJAR"
ENTRIES=$(unzip -Z1 "$FATJAR" | grep -E '^BOOT-INF/lib/.*\.jar$' || true)

declare -A RULES
RULES['^BOOT-INF/lib/jackson-core-2\.21\..*\.jar$']="jackson-core-2.21.7.jar"
RULES['^BOOT-INF/lib/jackson-databind-2\.21\..*\.jar$']="jackson-databind-2.21.7.jar"
RULES['^BOOT-INF/lib/jackson-core-2\.22\..*\.jar$']="jackson-core-2.22.3.jar"
RULES['^BOOT-INF/lib/jackson-databind-2\.22\..*\.jar$']="jackson-databind-2.22.3.jar"
RULES['^BOOT-INF/lib/jackson-core-3\..*\.jar$']="tools-jackson-core-3.1.7.jar"
RULES['^BOOT-INF/lib/jackson-databind-3\..*\.jar$']="tools-jackson-databind-3.1.7.jar"
RULES['^BOOT-INF/lib/guava-3[0-9]\..*-jre\.jar$']="guava-33.7.2-jre.jar"
RULES['^BOOT-INF/lib/snappy-java-1\.1\.10\..*\.jar$']="snappy-java-1.1.10.9.jar"
RULES['^BOOT-INF/lib/lz4-java-1\.11\..*\.jar$']="lz4-java-1.11.4.jar"
RULES['^BOOT-INF/lib/spring-webmvc-7\.0\..*\.jar$']="spring-webmvc-7.0.9.jar"
RULES['^BOOT-INF/lib/bcprov-jdk18on-1\.84\.jar$']="bcprov-jdk18on-1.85.jar"
RULES['^BOOT-INF/lib/jline-4\.2\.1\.jar$']="jline-4.3.1.jar"

DEL_LIST=()
declare -A NEWFILES   # target entry -> fixed jar source
declare -A REPL       # old entry -> target entry

while IFS= read -r entry; do
  [ -z "$entry" ] && continue
  for pat in "${!RULES[@]}"; do
    if [[ "$entry" =~ $pat ]]; then
      fixedjar="${RULES[$pat]}"
      target="BOOT-INF/lib/${fixedjar}"
      if [[ "$entry" == "$target" ]]; then break; fi
      DEL_LIST+=("$entry")
      NEWFILES["$target"]="$FIXED/${fixedjar}"
      REPL["$entry"]="$target"
      echo "[patch]   $entry  ->  $target"
      break
    fi
  done
done <<< "$ENTRIES"

if [ ${#DEL_LIST[@]} -eq 0 ]; then
  echo "[patch] No vulnerable nested jars found; nothing to do."
  exit 0
fi

echo "[patch] Deleting ${#DEL_LIST[@]} old nested jars"
zip -q -d "$FATJAR" "${DEL_LIST[@]}"

echo "[patch] Adding ${#NEWFILES[@]} fixed nested jars (stored)"
mkdir -p "$WORK/add/BOOT-INF/lib"
cd "$WORK/add"
for target in "${!NEWFILES[@]}"; do
  cp "${NEWFILES[$target]}" "$target"
  zip -q -0 -g "$FATJAR" "$target"
done

echo "[patch] Updating BOOT-INF/classpath.idx"
mkdir -p "$WORK/idx/BOOT-INF"
if unzip -Z1 "$FATJAR" | grep -qx "BOOT-INF/classpath.idx"; then
  unzip -p "$FATJAR" BOOT-INF/classpath.idx > "$WORK/idx/BOOT-INF/classpath.idx"
  for old in "${!REPL[@]}"; do
    new="${REPL[$old]}"
    oldesc=$(printf '%s' "$old" | sed 's/[.[\*^$/]/\\&/g')
    newesc=$(printf '%s' "$new" | sed 's/[&/\\]/\\&/g')
    sed -i "s|$oldesc|$newesc|g" "$WORK/idx/BOOT-INF/classpath.idx"
  done
  cd "$WORK/idx"
  zip -q -0 "$FATJAR" "BOOT-INF/classpath.idx"
else
  echo "[patch]   (no classpath.idx present)"
fi

echo "[patch] Done. Verifying physical nested jars:"
unzip -Z1 "$FATJAR" | grep -E '^BOOT-INF/lib/(jackson-core-2|jackson-databind-2|jackson-core-3|jackson-databind-3|guava-3[0-9]|snappy-java|lz4-java|spring-webmvc|bcprov|jline)' | sort
echo "[patch] classpath.idx references:"
unzip -p "$FATJAR" BOOT-INF/classpath.idx 2>/dev/null | grep -E "jackson-core-2|jackson-databind-2|guava-3[0-9]|snappy-java|lz4-java|spring-webmvc|bcprov|jline" | sort
