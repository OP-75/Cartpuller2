package com.hitesh.cartpuller2.order;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hitesh.cartpuller2.service.Helper;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
@RequestMapping("/api/order")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final Helper helper;

    @PostMapping("/user-order")
    public ResponseEntity<Order> postMethodName(@RequestBody Map<String, Integer> cart, HttpServletRequest request) {

        return ResponseEntity.ok(orderService.createOrder(cart, helper.getEmailFromRequest(request)));
    }

}