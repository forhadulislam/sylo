# Sylo

A Golang microservice helper.

<div align="center">
  <img width="300" height="300" src="https://github.com/forhadulislam/sylo/assets/1941100/a326b170-fbbf-4841-913b-cb5f189755c3" alt="Sylo logo">
</div>

### How should you `Sylo`

* You can just clone this repository and start working with your MicroService project
* Sylo is developed for Monorepo based projects
* You can have as many Microservices as you want. (Services can be found in `services` directory)
* You can create your own custom packages too. (All of the custom packages can be found in `packages` directory)

### How to create a new Service

To create a new service with `Sylo` use this command

    make create-service

You will have to input a unique service name. And it requires to provide service names without any `spaces`. If you have created a new service successfully then you should see a new directory created inside the `./service` directory with the same name you provided for the service.

### Git Hooks

Sylo uses `pre-commit` git hooks to run some commands before committing.

To use git hooks you need to install `pre-commit` package. You can install it by running this command

    brew install pre-commit

or you can install it using `pip`

    pip install pre-commit

After installing `pre-commit` you need to run this command to install the hooks

    pre-commit install

### How to run a Service

# This is a Work in Progress. Do not use it until it's ready.
