package com.hitesh.cartpuller2.cartpuller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hitesh.cartpuller2.cartpuller.dto.CartpullerOrderDto;
import com.hitesh.cartpuller2.global.dto.Activity;
import com.hitesh.cartpuller2.global.dto.Location;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/cartpuller")
@RequiredArgsConstructor
@Slf4j
public class CartpullerController {

    private final CartpullerService cartpullerService;

    @GetMapping("/check-token-validity")
    public ResponseEntity<String> checkTokenValidity() {
        return ResponseEntity.ok("Ok");
    }

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

    @GetMapping("/check-if-active")
    public ResponseEntity<Activity> checkIfActive(HttpServletRequest request) {
        return ResponseEntity.ok(cartpullerService.checkActive(request));
    }

    @GetMapping("/orders")
    public ResponseEntity<List<CartpullerOrderDto>> getOrders(HttpServletRequest request) {
        return ResponseEntity.ok(cartpullerService.getOrdersIfActive(request));
    }

    @GetMapping("/past-accepted-orders")
    public ResponseEntity<List<CartpullerOrderDto>> getPastAcceptedOrders(HttpServletRequest request) {
        return ResponseEntity.ok(cartpullerService.getCartpullerPastOrders(request));
    }

    @PostMapping("/accept-order/{orderId}")
    public ResponseEntity<CartpullerOrderDto> acceptCartpullerOrder(HttpServletRequest request,
            @PathVariable String orderId) {
        return ResponseEntity.ok(cartpullerService.acceptOrderIfActive(request, orderId));
    }

}
