package com.hitesh.cartpuller2.cartpuller;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface ActiveCartpullerRepository extends MongoRepository<ActiveCartpuller, String> {
    Optional<ActiveCartpuller> findByEmail(String email);
}
