package com.hitesh.cartpuller2.cartpuller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hitesh.cartpuller2.cartpuller.dto.Location;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/cartpuller")
@RequiredArgsConstructor
@Slf4j
public class CartpullerController {

    private final CartpullerService cartpullerService;

    @PostMapping("/activate")
    public ResponseEntity<String> activate(@RequestBody Location location, HttpServletRequest request) {
        cartpullerService.activateCartpuller(location, request);
        return ResponseEntity.ok("Ok");
    }

    @PostMapping("/deactivate")
    public ResponseEntity<String> deactivate(HttpServletRequest request) {
        cartpullerService.deactivateCartpuller(request);
        return ResponseEntity.ok("Ok");
    }

    @PostMapping("/update-location")
    public ResponseEntity<String> updateLocation(@RequestBody Location location, HttpServletRequest request) {
        cartpullerService.updateCartpullerLocation(location, request);
        return ResponseEntity.ok("Ok");
    }

}
