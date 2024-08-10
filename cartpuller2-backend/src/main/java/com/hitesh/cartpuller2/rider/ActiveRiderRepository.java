package com.hitesh.cartpuller2.rider;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface ActiveRiderRepository extends MongoRepository<ActiveRider, String> {
    Optional<ActiveRider> findByEmail(String email);
}
