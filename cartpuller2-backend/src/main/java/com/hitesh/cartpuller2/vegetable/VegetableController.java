package com.hitesh.cartpuller2.vegetable;

import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
public class VegetableController {

    private final VegetableService vegetableService;

    public VegetableController(VegetableService vegetableService) {
        this.vegetableService = vegetableService;
    }

    @GetMapping("/all-vegetables")
    public List<Vegetable> getAllVegetables() {
        return vegetableService.getAllVegetables();
    }

}
