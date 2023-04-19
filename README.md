# Project

[ Project Name ](https://project.com)

### Author

- gautier.tiehoule@ngser.com

##### Prerequisites

The setups steps expect following tools installed on the system.

- Git [2.34.1](https://git-scm.com)
- Ruby [3.0.6](https://ruby-doc.org)
- Rails [7.0.4](https://guides.rubyonrails.org)
- Postgres [](https://www.postgresql.org)
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

### Run the image project in the container

```bash
docker-compose up
```
