# Shotgun

This gem facilitates DNS-based Service Discovery, enabling you to easily code external services into your application.

It is capable of "wrapping" any executable to setup the Hosted Zone (more on that below). The best use case for this is running an API inside the gem. Shotgun is also provided as a Docker container (`stockflare/shotgun:latest`) that takes care of most of its installation and usage.

Unlike more other complicated solutions, Shotgun is very simple. It relies on a simple FQDN structure and a Hosted Zone (something like [AWS Route 53](http://aws.amazon.com/route53/)). For solutions hosted inside a private VPC, you could also make this a privately hosted zone, so that your services are not exposed to the internet via DNS.

Shotgun is capable of producing a URL for usage based upon the arguments provided to it.

## Example

Lets use AWS, we have a privately hosted VPC (with DNS configured), running its own Private Hosted Zone with the name `vpc-private-domain.com`. We have two Alias (A) records that are associated with two services running inside the VPC; Etcd is located at `etcd.vpc-private-domain.com` and some sort of internal admins API, located at `admin.internal.vpc-private-domain.com`.

Once Shotgun is correctly setup, we could then programmatically access these services by doing the following calls:

```
Shotgun.url_for(:etcd) #=> "etcd.vpc-private-domain.com"
```

We would also be able to retrieve an accessible URL for the Admins API using the following commands:

```
Shotgun.url_for(:admin, :internal)
```

### Development

If you want to network services during development, you can override DNS Discovery by providing a hardcoded Environment variable, matching the following structure:

Given a service available at `etcd.vpc-private-domain.com`, the variable would be `SERVICE_ETCD_URL`

Given a service available at `admin.internal.vpc-private-domain.com`, that variable would be `SERVICE_ADMIN_INTERNAL_URL`.
