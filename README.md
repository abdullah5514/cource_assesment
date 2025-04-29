# Course Assessment Project

This project is a Rails application designed to manage courses and assessments. It includes features for booking systems, course management, and an overview dashboard.

## Features

- Course Management
- Booking Systems
- Overview Dashboard
- User Authentication
- Responsive UI with Tailwind CSS and Shadcn

## Getting Started

### Prerequisites

- Ruby version: 3.0.0 or higher
- Rails version: 7.0.0 or higher
- Node.js and Yarn for asset compilation

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/abdullah5514/cource_assesment.git
   cd cource_assesment
   ```

2. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```

3. Setup the database:
   ```bash
   rails db:create db:migrate db:seed
   ```

4. Start the server:
   ```bash
   rails server
   ```

5. Visit `http://localhost:3000` in your browser.

## Testing

Run the test suite with:
```bash
rails test
```

## Deployment

This application can be deployed using Docker. Use the provided `Dockerfile` and `docker-compose.yml` for containerized deployment.

## Docker Setup

1. Ensure Docker is installed on your system.

2. Build the Docker image:
   ```bash
   sudo docker build -t cource_assesment .
   ```

3. Run the Docker container in development mode:
   ```bash
   sudo docker run -it --rm -v $(pwd):/app -w /app -p 3000:3000 -e RAILS_ENV=development cource_assesment /bin/bash
   ```

4. Inside the container, start the Rails server:
   ```bash
   bundle exec rails s -b 0.0.0.0
   ```

5. The application will be available at `http://localhost:3000`.

6. To stop the container, run:
   ```bash
   sudo docker stop <container_id>
   ```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
