# Project

[ [VIGNETTE PAYMENT USSD - GUINEE CONAKRY] ](https://ngser.com)

### Author

- gautier.tiehoule@ngser.com

### Prerequisites

The setups steps expect following tools installed on the system.

- Git [2.34.1](https://git-scm.com)
- Ruby [3.0.6](https://ruby-doc.org)
- Rails [7.0.4](https://guides.rubyonrails.org)
- Postgres [13](https://www.postgresql.org)
- Redis [4.0](https://redis.io)
- Docker [23.0.3](https://www.docker.com)
- Docker Compose [1.29.2](https://docs.docker.com/compose)

## Install and Run

### Clone the repository

```shell
git clone git@github.com:username/project.git
cd project
```

### Create environment variables file

Copy the sample .env.example file and edit the variables configuration as required.

```bash
cp .env.example .env
```

### Create docker image

```bash
docker-compose build --no-cache
```

### Upgrade application dependencies

```bash
docker-compose run web bundle
```

### Create database

```bash
docker-compose run web rails db:create
```

### Perform database migration file(s)

```bash
docker-compose run web rails db:migrate
```

### Run all service images project in a container

```bash
docker-compose up
```

### Run all service images project in a container - detached mode

```bash
docker-compose up -d
```
