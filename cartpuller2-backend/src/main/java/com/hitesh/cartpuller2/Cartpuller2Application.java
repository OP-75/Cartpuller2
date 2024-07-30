package com.hitesh.cartpuller2;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class Cartpuller2Application {

	public static final Logger log = LoggerFactory.getLogger(Cartpuller2Application.class);

	public static void main(String[] args) {
		SpringApplication.run(Cartpuller2Application.class, args);

		log.info("------------Server started------------");
	}

}
