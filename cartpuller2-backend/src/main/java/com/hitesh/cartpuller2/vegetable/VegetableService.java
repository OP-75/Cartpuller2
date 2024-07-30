package com.hitesh.cartpuller2.vegetable;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class VegetableService {

    private final VegetableRepository repository;

    public VegetableService(VegetableRepository repository) {
        this.repository = repository;
    }

    @Cacheable("all-vegetables")
    public List<Vegetable> getAllVegetables() {
        return repository.findAll();
    }

}
