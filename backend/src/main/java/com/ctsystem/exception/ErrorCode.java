package com.ctsystem.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    // Common
    INVALID_INPUT(HttpStatus.BAD_REQUEST, "Invalid input"),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Internal server error"),

    // Problem
    PROBLEM_NOT_FOUND(HttpStatus.NOT_FOUND, "Problem not found"),

    // Submission
    SUBMISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "Submission not found"),

    // Execution
    EXECUTION_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "Code execution failed"),
    RATE_LIMIT_EXCEEDED(HttpStatus.TOO_MANY_REQUESTS, "Rate limit exceeded");

    private final HttpStatus status;
    private final String message;
}
