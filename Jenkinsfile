pipeline {
  environment {
    IMAGE_NAME = "ic-webapp"
    USER_NAME = "maninax"

    IMAGE_TAG = """${sh(returnStdout: true, script: "grep version releases.txt | awk -F': ' '{print \$2}'")}"""
    ODOO_URL = """${sh(returnStdout: true, script: "grep ODOO_URL releases.txt | awk -F': ' '{print \$2}'")}"""
    PGADMIN_URL = """${sh(returnStdout: true, script: "grep PGADMIN_URL releases.txt | awk -F': ' '{print \$2}'")}"""

    WORKER2_HOSTNAME = """${sh(returnStdout: true, script: 'grep PGADMIN_URL releases.txt | perl -pe "s~PGADMIN_URL: ?https?://([A-Za-z0-9.]+)(:\\d+)?(/.*$)?~\\1~"')}"""
    WORKER3_HOSTNAME = """${sh(returnStdout: true, script: 'grep ODOO_URL releases.txt | perl -pe "s~ODOO_URL: ?https?://([A-Za-z0-9.]+)(:\\d+)?(/.*$)?~\\1~"')}"""

    IC_WEBAPP_PORT = "80"
    PGADMIN_PORT = """${sh(returnStdout: true, script: 'echo PGADMIN_URL | grep -Po "//.+?:.+/?" | grep -Po "(?<=:)(\\d+)" || echo "80"')}"""
    ODOO_PORT = """${sh(returnStdout: true, script: 'echo ODOO_URL | grep -Po "//.+?:.+/?" | grep -Po "(?<=:)(\\d+)" || echo "80"')}"""
    POSTGRES_PORT = "5432"

    ODOO_DATABASE_VOLUME = "" // #TODO: find a good path for the Odoo DB
  }

  agent any

  stages {
    stage ('Build docker image') {
        steps{
            script{
                sh '''
                cd 'sources/docker/ic-webapp';
                docker build -t ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .;
                '''
            }
        }
    }

    stage ('Test docker image') {
        steps{
            script{
            sh '''
                docker stop ${CONTAINER_NAME} || true;
                docker rm ${CONTAINER_NAME} || true;
                docker run -d --name ${CONTAINER_NAME} -p 9090:8080 ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG};
                sleep 3;
                curl http://localhost:9090 | grep -q "IC GROUP";
                docker stop ${CONTAINER_NAME};
                docker rm ${CONTAINER_NAME};
            '''
            }
        }
    }

/*
    stage ('Login and push docker image') {
        environment {
            DOCKERHUB_PASSWORD  = credentials('dockerhub')
        }
        steps {
            script {
            sh '''
                echo "${DOCKERHUB_PASSWORD}" | docker login -u ${USER_NAME} --password-stdin;
                docker push ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG};
            '''
            }
        }
    }
*/

    stage ('Deploy to prod with Ansible') {
        steps {
            withCredentials([
                usernamePassword(credentialsId: 'ansible_user_credentials', usernameVariable: 'ansible_user', passwordVariable: 'ansible_pass'),
                usernamePassword(credentialsId: 'pgadmin_credentials', usernameVariable: 'pgadmin_user', passwordVariable: 'pgadmin_pass'),
                usernamePassword(credentialsId: 'pgsql_credentials', usernameVariable: 'pgsql_user', passwordVariable: 'pgsql_pass'),
                usernamePassword(credentialsId: 'odoo_credentials', usernameVariable: 'odoo_user', passwordVariable: 'odoo_pass')
            ]){
            ansiblePlaybook (
                disableHostKeyChecking: true,
                installation: 'ansible',
                inventory: 'sources/ansible/hosts.yml',
                playbook: 'sources/ansible/playbooks/main.yml', // A playbook to play all playbooks, and in the darkness bind them
                extras: '--extra-vars "ansible_user=${ansible_user} \
                    ansible_password=${ansible_pass} \
                    ic_webapp_name=${IMAGE_NAME} \
                    ic_webapp_image=${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG} \
                    ic_webapp_port=${IC_WEBAPP_PORT} \
                    odoo_url=${ODOO_URL} \
                    odoo_port=${ODOO_PORT} \
                    odoo_username=${odoo_user} \
                    odoo_password=${odoo_pass} \
                    odoo_database=odoo \
                    pgadmin_url=${PGADMIN_URL} \
                    pgadmin_port=${PGADMIN_PORT} \
                    pg_admin_email=${pgadmin_user} \
                    pg_admin_password=${pgadmin_pass} \
                    postgres_hostname=${WORKER3_HOSTNAME} \
                    postgres_port=${POSTGRES_PORT} \
                    postgres_user=${pgsql_user} \
                    postgres_password=${pgsql_pass} \
                "')
            }
        }
    }

    stage ('Test full deployment') {
        steps {
            sh '''
                curl -LI http://${PGADMIN_HOSTNAME}:80 | grep "200";
                curl -L http://${PGADMIN_HOSTNAME}:80 | grep "IC GROUP";

                curl -LI ${ODOO_URL} | grep "200";
                curl -L ${ODOO_URL} | grep "Odoo";

                curl -LI ${PGADMIN_URL} | grep "200";
                curl -L ${PGADMIN_URL} | grep "pgAdmin 4";
            '''
        }
    }
  }
}

