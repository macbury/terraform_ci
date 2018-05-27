Configure AWS instance to host https://github.com/bleenco/abstruse

## Bootstrap Mac OS X

```
brew cask install ngrok
brew install ansible
brew install terraform
```

## Preparing infrastructure

Run terraform to create AWS instance
``` shell
terraform apply
```

## Testing provisioning

Run ngrok and copy http address
```
ngrok http 8080
```

Start vagrant. At first run provisioning is runned
``` shell
vagrant up
```

To run it another time just write:
``` shell
vagrant provision
```

https://alex.dzyoba.com/blog/terraform-ansible/

## Example job
```
image: test
matrix:
  - env: RAILS_ENV=test # required!
script:
  - sleep 60
  - echo "Works!"
```

https://medium.com/@mglover/deploying-to-aws-with-terraform-and-ansible-81cccd4c563e
http://www.sanjeevnandam.com/blog/ec2-mount-ebs-volume-during-launch-time
