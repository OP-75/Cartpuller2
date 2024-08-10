package com.hitesh.cartpuller2.rider;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import com.hitesh.cartpuller2.global.data.ErrorResponse;
import com.hitesh.cartpuller2.rider.exception.RiderInactiveException;

@RestControllerAdvice
public class RiderExceptionHandler {

    @ExceptionHandler(RiderInactiveException.class)
    public ResponseEntity<ErrorResponse> riderInactiveException(Exception e) {
        return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
    }
}
