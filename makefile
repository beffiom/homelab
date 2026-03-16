MEDIA ?= audiobookshelf jellyfin kiwix readeck
ARR ?= audiobookrequest bazarr prowlarr radarr seerr sonarr soulsolid
SERVICES ?= archivebox archivebox-scheduler archivebox-sonic cook
TOOLS ?= it-tools morphos myip
STORAGE ?= copyparty immich immich-machine-learning immich-db immich-redis paperless paperless-redis
NETWORKING ?= flaresolverr gluetun qbittorrent
MONITORING ?= mafl prometheus tracearr tracearr-db tracearr-redis
SECURITY ?= authentik vaultwarden
export MEDIA ARR SERVICES TOOLS STORAGE NETWORKING MONITORING SECURITY

.PHONY: %-up %-down

%-up %-down:
	@BASE=$$(echo $* | sed 's/-[^d]*$$//'); \
	if [ "$$BASE" = "tools" ]; then \
		SERVICES_LIST="$(TOOLS)"; \
	elif [ "$$BASE" = "media" ]; then \
		SERVICES_LIST="$(MEDIA)"; \
	elif [ "$$BASE" = "arr" ]; then \
		SERVICES_LIST="$(ARR)"; \
	elif [ "$$BASE" = "services" ]; then \
		SERVICES_LIST="$(SERVICES)"; \
	elif [ "$$BASE" = "storage" ]; then \
		SERVICES_LIST="$(STORAGE)"; \
	elif [ "$$BASE" = "networking" ]; then \
		SERVICES_LIST="$(NETWORKING)"; \
	elif [ "$$BASE" = "monitoring" ]; then \
		SERVICES_LIST="$(MONITORING)"; \
	elif [ "$$BASE" = "security" ]; then \
		SERVICES_LIST="$(SECURITY)"; \
	elif SERVICES=$$(grep -r --include="*.yml" "container_name:.*$$BASE" . 2>/dev/null | sed -E 's/.*container_name: *([^ ]+).*/\1/' | grep -E "^$$BASE|^$$BASE-" | head -5 | tr '\n' ' '); [ -n "$$SERVICES" ]; then \
		SERVICES_LIST=$$SERVICES; \
	else \
		echo "No services for '$$BASE'"; exit 1; \
	fi; \
	if echo "$(@)" | grep -q "up"; then \
		echo "podman-compose up -d $$SERVICES_LIST # group $$BASE"; \
		podman-compose up -d $$SERVICES_LIST; \
	else \
		echo "podman-compose down $$SERVICES_LIST # group $$BASE"; \
		podman-compose down $$SERVICES_LIST; \
	fi;
