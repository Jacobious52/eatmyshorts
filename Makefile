build-linux:
	docker run --rm \
		-v ${PWD}:/code \
		-v ${HOME}/.cargo/registry:/root/.cargo/registry \
		-v ${HOME}/.cargo/git:/root/.cargo/git \
		softprops/lambda-rust

test-invoke: build-linux
	unzip -o \
		target/lambda/release/bootstrap.zip \
		-d /tmp/lambda && \
  	docker run \
		-i -e DOCKER_LAMBDA_USE_STDIN=1 \
		--rm \
		-v /tmp/lambda:/var/task \
		lambci/lambda:provided < input.json

terraform_init:
	cd aws && \
	terraform init

plan: terraform_init
	cd aws && \
	terraform plan

deploy: build-linux terraform_init
	cd aws && \
	terraform apply


invoke-lambda:
	aws lambda invoke --function-name eatmyshorts \
  		--payload '{"url": "https://www.google.com/", "exp": "2020-11-28T12:45:59Z"}' invoke-output.json
