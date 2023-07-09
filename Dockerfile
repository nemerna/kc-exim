FROM quay.io/ecosystem-appeng/keycloak-source:latest as keycloak

FROM registry.access.redhat.com/ubi9/openjdk-11-runtime
WORKDIR /opt/keycloak/bin
ARG KEYCLOAK_VERSION=21.1.1

USER root
# COPY ca-bundle.crt /etc/pki/ca-trust/source/anchors
# RUN update-ca-trust extract
# RUN trust list --filter=ca-anchors | grep ingress -A3

RUN microdnf install -y jq
RUN mkdir -p /opt/keycloak/bin/client/lib/

COPY --from=keycloak /opt/keycloak/bin/client/keycloak-admin-cli-${KEYCLOAK_VERSION}.jar client
COPY --from=keycloak /opt/keycloak/bin/client/lib/ client/lib/
COPY --from=keycloak /opt/keycloak/bin/kcadm.sh .

COPY user-import.sh /opt/keycloak/bin/user-import.sh
COPY user-export.sh /opt/keycloak/bin/user-export.sh
COPY groups-ids-wrapper.sh /opt/keycloak/bin/groups-ids-wrapper.sh
COPY Entrypoint.sh /opt/keycloak/bin/Entrypoint.sh

RUN chmod +x /opt/keycloak/bin/Entrypoint.sh
RUN chmod +x /opt/keycloak/bin/kcadm.sh
RUN chmod +x /opt/keycloak/bin/user-import.sh
RUN chmod +x /opt/keycloak/bin/user-export.sh
RUN chmod +x /opt/keycloak/bin/groups-ids-wrapper.sh

USER 185
ENTRYPOINT ["/opt/keycloak/bin/Entrypoint.sh"]
