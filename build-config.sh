#!/bin/sh

export user=$(id -u -n)
touch /opt/opencps/build.${user}.properties
echo 'app.server.type = jboss' >> /opt/opencps/build.${user}.properties
echo 'app.server.parent.dir = /opt/server' >> /opt/opencps/build.${user}.properties
echo 'app.server.jboss.dir = ${app.server.parent.dir}/'$servertype >> /opt/opencps/build.${user}.properties
echo 'app.server.jboss.deploy.dir = ${app.server.jboss.dir}/deploy' >> /opt/opencps/build.${user}.properties
echo 'app.server.jboss.lib.global.dir = ${app.server.jboss.dir}/modules/com/liferay/portal/main' >> /opt/opencps/build.${user}.properties
echo 'app.server.jboss.portal.dir = ${app.server.jboss.dir}/standalone/deployments/ROOT.war' >> /opt/opencps/build.${user}.properties
echo 'company.default.locale=vi_VN' >> /opt/server/portal-setup-wizard.properties
