pipeline {
    agent any

    stages {
        stage('Clone the Repo') {
            steps {
                git branch: 'main', credentialsId: 'Github', url: 'https://github.com/gznaIT/django-notes-app.git'
            }
        }

        stage('Create Virtual Environment and Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv Django
                    ./Django/bin/pip install --upgrade pip
                    ./Django/bin/pip install "setuptools<74"
                    ./Django/bin/pip install -r requirements.txt
                '''
            }
        }

        stage('Run Django App') {
            steps {
                sh '''
                    ./Django/bin/python manage.py makemigrations
                    ./Django/bin/python manage.py migrate
                '''
            }
        }

        stage('Run with Gunicorn') {
            steps {
                sh '''
                    mkdir -p logs
                    
                    # Prevent Jenkins from killing Gunicorn after the build finishes
                    BUILD_ID=dontKillMe ./Django/bin/gunicorn notesapp.wsgi:application --bind 0.0.0.0:8000 \
                        --access-logfile logs/access.log \
                        --error-logfile logs/error.log &
                    
                    sleep 2
                    ps aux | grep gunicorn
                '''
            }
        }
    }
}
