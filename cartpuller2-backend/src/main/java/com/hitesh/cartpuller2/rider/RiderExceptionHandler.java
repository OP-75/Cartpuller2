package com.hitesh.cartpuller2.rider;

import java.util.NoSuchElementException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import com.hitesh.cartpuller2.global.data.ErrorResponse;
import com.hitesh.cartpuller2.rider.exception.AuthorizationException;
import com.hitesh.cartpuller2.rider.exception.BadRequestException;
import com.hitesh.cartpuller2.rider.exception.RiderAlreadyAssignedException;
import com.hitesh.cartpuller2.rider.exception.RiderInactiveException;

@RestControllerAdvice
public class RiderExceptionHandler {

    @ExceptionHandler(RiderInactiveException.class)
    public ResponseEntity<ErrorResponse> riderInactiveException(Exception e) {
        return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
    }

    @ExceptionHandler(RiderAlreadyAssignedException.class)
    public ResponseEntity<ErrorResponse> riderAlreadyAssignedException(Exception e) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(new ErrorResponse(e.getMessage()));
    }

    @ExceptionHandler(AuthorizationException.class)
    public ResponseEntity<ErrorResponse> authorizationException(Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse(e.getMessage()));
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorResponse> badRequestException(Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse(e.getMessage()));
    }

    @ExceptionHandler(NoSuchElementException.class)
    public ResponseEntity<ErrorResponse> noSuchElementException(Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse("Requested resource not found"));
    }
}
