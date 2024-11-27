[Rabbitmq](https://www.rabbitmq.com/) is a reliable and mature messaging and streaming broker, which is easy to deploy on cloud environments, on-premises, and on your local machine. 

# Installation

## Check that it's working

If RabbitMQ's Management Plugin is enabled, you can use a browser or curl to check the status of the server:

```bash
curl -i http://<rabbitmq-host>:15672/api/overview
```
Replace `<rabbitmq-host>` with your RabbitMQ server’s hostname or IP address. The default port for the management interface is 15672. You might need to provide credentials if the management plugin requires authentication:

```bash
curl -i -u guest:guest http://<rabbitmq-host>:15672/api/overview
```

If successful, you will get a JSON response with information about the server.

# References
- [Home](https://www.rabbitmq.com/)
