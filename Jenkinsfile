pipeline {
  environment {
    IMAGE_NAME = "ic-webapp"
    IMAGE_TAG = "${sh(returnStdout: true, script: 'grep version releases.txt | cut -d\\: -f2 | xargs')}"
    ODOO_URL = "${sh(returnStdout: true, script: 'grep ODOO_URL releases.txt | cut -d\\: -f2 | xargs')}"
    POSTGRES_HOSTNAME = """${sh(returnStdout: true, script: 'grep ODOO_URL releases.txt | perl -pe "s~ODOO_URL: ?https?://([A-Za-z0-9.]+)(:\\d+)?(/.*$)?~\\1~"')}"""
    PGADMIN_URL = "${sh(returnStdout: true, script: 'grep PGADMIN_URL releases.txt | cut -d\\: -f2 | xargs')}"
    CONTAINER_NAME = "ic-webapp"
    USER_NAME = "maninax"
    PATH = "/usr/local/bin:${env.PATH}"
  }

  agent any

  stages {
    stage ('Build docker image') {
        when { changeset "releases.txt"}
        steps{
            script{
                sh '''
                cd 'ic-webapp';
                docker build -t ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .;
                '''
            }
        }
    }

    stage ('Test docker image') {
        when { changeset "releases.txt"}
        steps{
            script{
            sh '''
                docker stop ${CONTAINER_NAME} || true;
                docker rm ${CONTAINER_NAME} || true;
                docker run -d --name ${CONTAINER_NAME} -p 9090:8080 ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG};
                sleep 3;
                curl http://192.168.99.12:9090 | grep -q "IC GROUP";
                docker stop ${CONTAINER_NAME};
                docker rm ${CONTAINER_NAME};
            '''
            }
        }
    }

/*
    stage ('Login and push docker image') {
        when { changeset "releases.txt"}
        agent any
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
        steps { // Assume Ansible is installed by VM provisioning
            withCredentials([
                usernamePassword(credentialsId: 'ansible_user_credentials', usernameVariable: 'ansible_user', passwordVariable: 'ansible_user_pass'),
                usernamePassword(credentialsId: 'pgadmin_credentials', usernameVariable: 'pgadmin_user', passwordVariable: 'pgadmin_pass'),
                usernamePassword(credentialsId: 'pgsql_credentials', usernameVariable: 'pgsql_user', passwordVariable: 'pgsql_pass'),
                // string(credentialsId: 'ansible_sudo_pass', variable: 'ansible_sudo_pass')
            ]){
            sh "ls"
            ansiblePlaybook ( // TODO: put the correct infos there
                disableHostKeyChecking: true,
                installation: 'ansible',
                inventory: 'sources/ansible/hosts.yml',
                playbook: 'sources/ansible/play.yml', // A playbook to play all playbooks, and in the darkness bind them
                extras: '--extra-vars "NETWORK_NAME=network \
IMAGE_TAG=${IMAGE_TAG} \
ansible_user=${ansible_user} \
ansible_password=${ansible_user_pass} \
pg_admin_email=${pgadmin_user} \
pg_admin_password=${pgadmin_pass} \
odoo_user=${pgsql_user} \
odoo_password=${pgsql_pass} \
postgres_hostname=${POSTGRES_HOSTNAME} \
                        "')
            }
        }
    }

    stage ('Test full deployment') {
        steps {
            sh '''
                sleep 10;

                // Showcase website runs on the same server as the pgadmin 
                curl -LI ${PGADMIN_URL} | grep "200";
                curl -L ${PGADMIN_URL} | grep "IC GROUP";

                curl -LI ${ODOO_URL}:5432 | grep "200";
                curl -L ${ODOO_URL}:5432 | grep "Odoo";

                curl -LI ${PGADMIN_URL} | grep "200";
                curl -L ${PGADMIN_URL} | grep "pgAdmin 4";
            '''
        }
    }
  }
}

