package com.hitesh.cartpuller2.vegetable;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VegetableRepository extends MongoRepository<Vegetable, String> {
    // we automatically get findAll method from MongoRepository

}
