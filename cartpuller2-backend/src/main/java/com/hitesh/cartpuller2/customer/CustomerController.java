package com.hitesh.cartpuller2.customer;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hitesh.cartpuller2.customer.dto.DetailedOrderDto;
import com.hitesh.cartpuller2.rider.dto.RedactedOrderDto;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/customer")
@RequiredArgsConstructor
@Slf4j
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping("/check-token-validity")
    public ResponseEntity<String> checkTokenValidity() {
        return ResponseEntity.ok("Ok");
    }

    @GetMapping("/past-orders")
    public ResponseEntity<List<RedactedOrderDto>> getPastOrders(HttpServletRequest request) {
        return ResponseEntity.ok(customerService.getPastOrders(request));
    }

    @GetMapping("/order-details/{orderId}")
    public ResponseEntity<DetailedOrderDto> getOrderDetail(HttpServletRequest request,
            @PathVariable String orderId) {
        return ResponseEntity.ok(customerService.getOrderDetails(request, orderId));
    }

}
