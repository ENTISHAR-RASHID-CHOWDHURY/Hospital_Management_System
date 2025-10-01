export class AppError extends Error {
  constructor(public readonly statusCode: number, message: string, public readonly details?: unknown) {
    super(message);
    this.name = 'AppError';
  }
}

export function badRequest(message: string, details?: unknown): never {
  throw new AppError(400, message, details);
}

export function unauthorized(message: string = 'Unauthorized'): never {
  throw new AppError(401, message);
}

export function forbidden(message: string = 'Forbidden'): never {
  throw new AppError(403, message);
}

export function notFound(message: string = 'Not Found'): never {
  throw new AppError(404, message);
}
