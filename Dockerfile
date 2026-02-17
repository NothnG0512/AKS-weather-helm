# Use the official Nginx image as a starting point
FROM nginx:alpine

# Add a custom message to your "Weather App" homepage
RUN echo "<h1>Welcome to the Weather API - Version 1.0</h1>" > /usr/share/nginx/html/index.html

# Tell the container to listen on port 80
EXPOSE 80