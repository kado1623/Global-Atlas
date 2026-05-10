export class ApiException extends Error {
  readonly statusCode: number;

  constructor(statusCode: number, message: string) {
    super(message);
    this.name = "ApiException";
    this.statusCode = statusCode;
  }
}
