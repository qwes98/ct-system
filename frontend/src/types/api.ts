/**
 * API request/response type definitions for CT-System frontend
 * Based on API_SPECIFICATION.md
 */

import type { Language, SubmissionStatus } from './domain';

// Generic API response wrapper
export interface ApiResponse<T> {
  data: T;
  success: boolean;
  timestamp: string;
}

// API error object (nested within error response)
export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

// API error response wrapper
export interface ApiErrorResponse {
  success: false;
  error: ApiError;
  timestamp: string;
}

// Run request (execute sample tests only)
export interface RunRequest {
  problemId: number;
  language: Language;
  code: string;
}

// Run test result for individual test case
export interface RunTestResult {
  testCase: number;
  passed: boolean;
  executionTime: number;
  input: string;
  expected: string;
  actual: string;
}

// Run response
export interface RunResponse {
  status: string;
  totalTests: number;
  passedTests: number;
  hasError: boolean;
  executionTime?: number;
  memoryUsed?: number;
  errorType?: string;
  results: RunTestResult[];
}

// Submit request (execute all tests)
export interface SubmitRequest {
  problemId: number;
  language: Language;
  code: string;
}

// Submit response
export interface SubmitResponse {
  submissionId: string;
  status: SubmissionStatus;
  queuePosition?: number;
  estimatedWaitTime?: number;
}
