// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CarPaintingSimulator {
    struct Car {
        uint256 id;
        string model;
        uint8[3] targetColor; // RGB
        bool isPainted;
    }

    struct PaintingResult {
        uint8[3] paintedColor;
        uint8 score; // 0–100
    }

    uint256 public nextCarId = 1;
    mapping(uint256 => Car) public cars;
    mapping(address => mapping(uint256 => PaintingResult)) public playerResults;

    event CarAdded(uint256 carId, string model);
    event CarPainted(address indexed player, uint256 carId, uint8[3] color, uint8 score);

    /// Add a new car to the game
    function addCar(string memory model, uint8[3] memory targetColor) external {
        cars[nextCarId] = Car({
            id: nextCarId,
            model: model,
            targetColor: targetColor,
            isPainted: false
        });
        emit CarAdded(nextCarId, model);
        nextCarId++;
    }

    /// Player paints the car
    function paintCar(uint256 carId, uint8[3] memory color) external {
        Car storage car = cars[carId];
        require(!car.isPainted, "Car already painted");

        uint8 score = calculateScore(car.targetColor, color);

        playerResults[msg.sender][carId] = PaintingResult({
            paintedColor: color,
            score: score
        });

        car.isPainted = true;

        emit CarPainted(msg.sender, carId, color, score);
    }

    /// Internal function to calculate color accuracy score
    function calculateScore(uint8[3] memory target, uint8[3] memory input) internal pure returns (uint8) {
        uint256 totalDiff;
        for (uint256 i = 0; i < 3; i++) {
            totalDiff += absDiff(target[i], input[i]);
        }

        // Max difference is 255 * 3 = 765
        uint256 accuracy = 100 - (totalDiff * 100 / 765);
        return uint8(accuracy);
    }

    function absDiff(uint8 a, uint8 b) internal pure returns (uint8) {
        return a > b ? a - b : b - a;
    }

    /// View score
    function getScore(address player, uint256 carId) external view returns (uint8) {
        return playerResults[player][carId].score;
    }
}
