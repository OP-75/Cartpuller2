package com.hitesh.cartpuller2.rider;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.hitesh.cartpuller2.global.dto.Activity;
import com.hitesh.cartpuller2.global.dto.Location;
import com.hitesh.cartpuller2.rider.dto.RiderOrderDetailedDto;
import com.hitesh.cartpuller2.rider.dto.RiderOrderRedactedDto;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/rider")
@RequiredArgsConstructor
@Slf4j
public class RiderController {

    private final RiderService riderService;

    @GetMapping("/check-token-validity")
    public ResponseEntity<String> checkTokenValidity() {
        return ResponseEntity.ok("Ok");
    }

    @PostMapping("/activate")
    public ResponseEntity<String> activate(@RequestBody Location location, HttpServletRequest request) {
        riderService.activateRider(location, request);
        return ResponseEntity.ok("Ok");
    }

    @PostMapping("/deactivate")
    public ResponseEntity<String> deactivate(HttpServletRequest request) {
        riderService.deactivateRider(request);
        return ResponseEntity.ok("Ok");
    }

    @PostMapping("/update-location")
    public ResponseEntity<String> updateLocation(@RequestBody Location location, HttpServletRequest request) {
        riderService.updateRiderLocation(location, request);
        return ResponseEntity.ok("Ok");
    }

    @GetMapping("/check-if-active")
    public ResponseEntity<Activity> checkIfActive(HttpServletRequest request) {
        return ResponseEntity.ok(riderService.checkActive(request));
    }

    @GetMapping("/orders")
    public ResponseEntity<List<RiderOrderDetailedDto>> getOrders(HttpServletRequest request) {
        return ResponseEntity.ok(riderService.getOrdersIfActive(request));
    }

    @GetMapping("/past-accepted-orders")
    public ResponseEntity<List<RiderOrderRedactedDto>> getPastAcceptedOrders(HttpServletRequest request) {
        return ResponseEntity.ok(riderService.getPastOrders(request));
    }

    @GetMapping("/accepted-order-details/{orderId}")
    public ResponseEntity<RiderOrderDetailedDto> getAcceptedOrderDetails(HttpServletRequest request,
            @PathVariable String orderId) {
        return ResponseEntity.ok(riderService.getAccepedOrderDetails(request, orderId));
    }

    @PostMapping("/accept-order/{orderId}")
    public ResponseEntity<RiderOrderDetailedDto> acceptOrder(HttpServletRequest request,
            @PathVariable String orderId) {
        return ResponseEntity.ok(riderService.acceptOrderIfActive(request, orderId));
    }

    @PostMapping("/pickup-order/{orderId}")
    public ResponseEntity<RiderOrderDetailedDto> pickupOrder(HttpServletRequest request,
            @PathVariable String orderId) {
        return ResponseEntity.ok(riderService.pickupOrderIfActive(request, orderId));
    }

    @PostMapping("/deliver-order/{orderId}")
    public ResponseEntity<RiderOrderRedactedDto> deliverOrder(HttpServletRequest request,
            @PathVariable String orderId) {
        return ResponseEntity.ok(riderService.deliverOrderIfActive(request, orderId));
    }

}
