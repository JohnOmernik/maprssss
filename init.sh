#!/bin/bash

echo "MapR Streamsets Init Script"
sleep 2


if [ ! -d "$APP_CONF_DIR" ]; then
    echo "*********** APP_CONF_DIR: $APP_CONF_DIR not detected: Running initialization sciprts"
    echo ""
    for DIR in $APP_DIRS; do
        echo ""
        echo "Creating $DIR"
        mkdir -p $DIR
        if [ "$?" != "0" ]; then
            echo " **** Directory Creation failed  on $DIR - exiting ****"
            exit 1
        fi
    done
    export SDC_DIST="/opt/streamsets/streamsets-datacollector-${APP_VER}"
    echo "Copying default config items to $APP_HOME"
    echo ""
    echo "Copying etc and env files to proper location"
    mv ${SDC_DIST}/etc/* $APP_CONF_DIR/ && cp ${SDC_DIST}/libexec/sdc-env.sh $APP_CONF_DIR/ && cp ${SDC_DIST}/libexec/sdcd-env.sh $APP_CONF_DIR/
    if [ "$?" != "0" ]; then
        echo "Copy files failed - exiting"
        exit 1
    fi
    echo ""
    APP_SDC_CONF="$APP_CONF_DIR/sdc.properties"
    sed -r -i "s/^http\.port=.*/http.port=-1/g" $APP_SDC_CONF && sed -r -i "s/^https.port=.*/https.port=$APP_STREAMSETS_TCP_PORT/g" $APP_SDC_CONF
    if [ "$?" != "0" ]; then
        echo "Erroring updating config files - exiting"
        exit 1
    fi


    cat > ${APP_SBIN_DIR}/start.sh << EOS
#!/bin/bash

export SDC_DIST="/opt/streamsets/streamsets-datacollector-${APP_VER}"
export SDC_HOME="${SDC_DIST}"
export MAPR_VERSION=$MAPR_VERSION
export MAPR_MEP_VERSION=$MAPR_MEP_VERSION
export SDC_RESOURCES="${APP_RESOURCE_DIR}"
export SDC_DATA="${APP_DATA_DIR}"
export SDC_CONF="${APP_CONF_DIR}"
export SDC_LOG="${APP_LOG_DIR}"




echo "Copying over ENV Info"
cp ${APP_CONF_DIR}/sdc-env.sh $SDC_DIST/libexec/
cp ${APP_CONF_DIR}/sdcd-env.sh $SDC_DIST/libexec/

chmod 600 ${APP_CONF_DIR}/form-realm.properties

echo "Setting up MapR"
$SDC_DIST/bin/streamsets setup-mapr

echo "Starting Stream Sets"
$SDC_DIST/bin/streamsets dc
EOS
    sudo chmod +x $APP_SBIN_DIR/start.sh
    if [ "$?" != "0" ]; then
        echo "Erroring creating start script - exiting"
        exit 1
    fi
    echo "Init of Home Directory complete!"
    echo "Streamsets files located at MFS: $APP_HOME and Posix: $APP_POSIX_HOME"
    echo ""
else
    echo "APP_HOME directory found: Attempting to run"
fi

if [ -f "$APP_SBIN_DIR/start.sh" ]; then
    echo "Starting MapR Streamsets!"
    $APP_SBIN_DIR/start.sh
else
    echo "While APP_HOME of $APP_HOME appears to exist, there is no $APP_SBIN_DIR/start.sh. You may want to remove the $APP_HOME directory and start again"
fi







