# Shotgun

This gem facilitates DNS-based Service Discovery, enabling you to easily code external services into your application.

It is capable of "wrapping" any executable to setup the Hosted Zone (more on that below). The best use case for this is running an API inside the gem. Shotgun is also provided as a Docker container (`stockflare/shotgun:latest`) that takes care of most of its installation and usage.

Unlike more other complicated solutions, Shotgun is very simple. It relies on a simple FQDN structure and a Hosted Zone (something like [AWS Route 53](http://aws.amazon.com/route53/)). For solutions hosted inside a private VPC, you could also make this a privately hosted zone, so that your services are not exposed to the internet via DNS.

## Example

Lets use AWS, we have a privately hosted VPC (with DNS configured), running its own Private Hosted Zone with the name `vpc-private-domain.com`. We have two Alias (A) records that are associated with two services running inside the VPC; Etcd is located at `etcd.vpc-private-domain.com` and some sort of internal admins API, located at `admin.internal.vpc-private-domain.com`.

The Etcd service is just a plain Etcd container, like `microbox/etcd` with no Shotgun integration at all. The Internal Admins API has the following Dockerfile:

```
FROM stockflare/shotgun
```

The Shotgun Dockerfile sets an entrypoint of `['shotgun']`. The API can be normally ran by running `puma`. We can kick-start the Shotgun integration by passing the `-zone` flag into the command line. In this case, we can then run the docker container by using:

```
docker run -P -d stockflare/internal-admin-api puma -zone vpc-private-domain.com
```

This will now enable our Internal Admins API to programmatically consume the Etcd service. In-turn, given that this API itself is accessible via `admin.internal.vpc-private-domain.com` we can now access the API programmatically using Shotgun as well.

### Accessing services programatically?

Now that our service is integrated, lets make use of the Shotgun gem to access the Etcd service through code. Lets first setup our Services class namespace:

```
module AdminsAPI
  class Services < Shotgun::Services
  end
end
```

The Admins API can then simply set a new key inside the Etcd service by running:

```
AdminsAPI::Services::Etcd.new(:v2, :keys, :a_key).update({ value: "a value" })
```

Shotgun takes care of everything else and will then send a `PUT` call to `http://etcd.vpc-private-domain.com/v2/keys/a_key/` setting the corect value.

It is important note that any service can be consumed using Shotgun, whether it is integrated directly or not.

### Nested routes services usage

Now we have established the basic usage of a micro-service, in the previous example, lets work through an example of updating the attributes of a pre-existing admin user.

The "gotcha" here, is that to update an admin, we must use a sub-path, aptly located under the route "/admins/:id". Were as before, users were simply mapped to the root path.

To use nested routes within a service, we must instantiate a service object.

```
admin = AdminsAPI::Services::Internal::Admin.new(:admins, admin_id) # => admin_id = 1234
```

With this new object, given the admin ID of 1234, this will now map calls to a nested path, namely "/admins/1234/" within the internal admins micro-service.

We can now very simply update this admin user by calling:

```
admin.update({ name: "David" })
```

This will map this call to an associated micro-service endpoint, using the CRUD standard for updating an instrument.

### Development

If you want to network services during development, you can override DNS Discovery by providing a hardcoded Environment variable, matching the following structure:

Given a service available at `etcd.vpc-private-domain.com`, the variable would be `SERVICE_ETCD_URL`

Given a service available at `admin.internal.vpc-private-domain.com`, that variable would be `SERVICE_ADMIN_INTERNAL_URL`.
