# GolMS

Golang microservice helper.

<p align="center">
  <img width="300" height="300" src="https://user-images.githubusercontent.com/1941100/90184574-fd830100-ddbd-11ea-9553-4e994483d6f2.png">
</p>

### How should you `GolMS`

* You can just clone this repository and start working with your MicroService project
* GolMS is developed for Monorepo based projects
* You can have as many Microservices as you want. (Services can be found in `services` directory)
* You can create your own custom packages too. (All of the custom packages can be found in `packages` directory)

### How to create a new Service 

To create a new service with GolMS use this command

  `make create-service`

You will have to input an unique service name. And it required to provice service names with any `spaces`. If you have created a new service successfully then you should a new directory created inside the `./service` directory with the same name you provided. 

# This is a Work in Progress. Do not use it until its ready.


