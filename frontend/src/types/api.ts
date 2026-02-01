/**
 * API request/response type definitions for CT-System frontend
 */

import type { Language, SubmissionStatus } from './domain';

// Generic API response wrapper
export interface ApiResponse<T> {
  data: T;
  success: boolean;
}

// API error response
export interface ApiError {
  error: string;
  message: string;
  status: number;
}

// Run request (execute sample tests only)
export interface RunRequest {
  problemId: number;
  language: Language;
  code: string;
}

// Run response
export interface RunResponse {
  passed: boolean;
  hasError: boolean;
}

// Submit request (execute all tests)
export interface SubmitRequest {
  problemId: number;
  language: Language;
  code: string;
}

// Submit response
export interface SubmitResponse {
  submissionId: number;
  status: SubmissionStatus;
}
