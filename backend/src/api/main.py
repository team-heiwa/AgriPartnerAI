"""FastAPI application with upload endpoints."""

import sys
import os

# Add the parent directory to Python path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.upload import router as upload_router


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    
    app = FastAPI(
        title="AgriPartner AI Backend",
        description="Backend service for processing agricultural media files",
        version="1.0.0"
    )
    
    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Configure appropriately for production
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Include routers
    app.include_router(upload_router)
    
    @app.get("/")
    async def root():
        """Health check endpoint."""
        return {"message": "AgriPartner AI Backend is running"}
    
    @app.get("/health")
    async def health_check():
        """Detailed health check."""
        return {
            "status": "healthy",
            "service": "agripartner-ai-backend",
            "version": "1.0.0"
        }
    
    return app


# Create app instance
app = create_app()


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8080,
        reload=False
    )