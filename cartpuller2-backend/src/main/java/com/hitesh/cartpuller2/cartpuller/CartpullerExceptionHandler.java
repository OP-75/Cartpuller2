package com.hitesh.cartpuller2.cartpuller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.hitesh.cartpuller2.cartpuller.exception.CartpullerNotActivatedException;
import com.hitesh.cartpuller2.cartpuller.exception.CartpullerOrderAlreadyAcceptedException;
import com.hitesh.cartpuller2.global.data.ErrorResponse;

@RestControllerAdvice
public class CartpullerExceptionHandler {

    @ExceptionHandler(CartpullerNotActivatedException.class)
    public ResponseEntity<ErrorResponse> handleCartpullerNotActivatedException(Exception e) {
        return new ResponseEntity<ErrorResponse>(new ErrorResponse(e.getMessage()), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(CartpullerOrderAlreadyAcceptedException.class)
    public ResponseEntity<ErrorResponse> handleCartpullerOrderAlreadyAcceptedException(Exception e) {
        return new ResponseEntity<>(new ErrorResponse(e.getMessage()), HttpStatus.CONFLICT);
    }
}
