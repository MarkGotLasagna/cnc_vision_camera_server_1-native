/**
 * @file camera_server.hpp
 * @brief CNC Vision Camera Server Header
 * @author Your Name
 * @date 2025
 */

#ifndef CNC_VISION_CAMERA_SERVER_HPP
#define CNC_VISION_CAMERA_SERVER_HPP

#include <memory>
#include <string>

namespace cnc_vision {

/**
 * @brief Camera server application class
 */
class CameraServer {
public:
    CameraServer();
    ~CameraServer();

    // Prevent copying
    CameraServer(const CameraServer&) = delete;
    CameraServer& operator=(const CameraServer&) = delete;

    // Allow moving
    CameraServer(CameraServer&&) = default;
    CameraServer& operator=(CameraServer&&) = default;

    /**
     * @brief Initialize the camera server
     * @return true if successful, false otherwise
     */
    bool initialize();

    /**
     * @brief Run the camera server
     * @return exit code
     */
    int run();

    /**
     * @brief Check if the server is initialized
     * @return true if initialized, false otherwise
     */
    bool isInitialized() const noexcept;

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};

} // namespace cnc_vision

#endif // CNC_VISION_CAMERA_SERVER_HPP
