#!/bin/bash
set -e

# Render kettle template
for f in $(find $KETTLE_TEMPLATES -type f); do
    envsubst < "$f" > "$KETTLE_HOME/.kettle/$(basename $f)"
done

# Render carte template
for f in $(find $CART_TEMPLATES -type f); do
    envsubst < "$f" > "$KETTLE_HOME/carte/$(basename $f)"
done

# Link the right template and replace the variables in it
if [ ! -e "$KETTLE_HOME/carte/carte-config.xml" ]; then
    if [ "$CARTE_INCLUDE_MASTERS" = "Y" ]; then
        ln -sf "$KETTLE_HOME/carte/carte-slave.xml" "$KETTLE_HOME/carte/carte-config.xml"
    else
        ln -sf "$KETTLE_HOME/carte/carte-master.xml" "$KETTLE_HOME/carte/carte-config.xml"
    fi
fi

# Run any custom scripts
for f in /etc/entrypoint/conf.d/*.sh; do
    [ -f "$f" ] && source "$f"
done

$@