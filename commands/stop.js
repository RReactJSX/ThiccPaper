const { Rcon } = require('rcon-client');
const fs = require('fs');
const path = require('path');

// Define RCON connection parameters
const rconConfig = {
    host: '::1',           // IPv6 localhost
    port: 25575,           // RCON port
    password: 'thiccpaper' // RCON password
};

// Function to send RCON commands
async function sendRconCommand(command) {
    try {
        const rcon = await Rcon.connect(rconConfig);
        const response = await rcon.send(command);
        console.log(`RCON Command '${command}' sent: ${response}`);
        await rcon.end(); // Close the RCON connection
        return response;
    } catch (err) {
        console.error(`Failed to send RCON command '${command}':`, err);
        throw err; // Re-throw the error to handle in caller function
    }
}

// Function to check if PaperMC server is running
const isServerRunning = async () => {
    try {
        // Send a status or query command via RCON (e.g., `list` command to get the number of players)
        const response = await sendRconCommand('list');
        if (response && response.includes('players')) {
            return true; // Server is running
        }
    } catch (err) {
        console.error('Failed to check server status:', err);
        return false; // Treat the error as server not running
    }
    return false; // Server is not running
};

// Function to stop the PaperMC server
const stopPaperMC = async () => {
    try {
        // Check if the server is running
        const running = await isServerRunning();

        if (running) {
            console.log('Server is running, attempting to stop it.');

            // Send the stop command via RCON
            await sendRconCommand('stop');
            console.log('Shutdown command sent successfully.');
        } else {
            console.log('Server is not running.');
        }

        // Delete the server.lock file
        const lockFilePath = path.join(__dirname, 'server.lock');
        if (fs.existsSync(lockFilePath)) {
            fs.unlinkSync(lockFilePath);
            console.log('Deleted server.lock file.');
        } else {
            console.log('server.lock file not found.');
        }
    } catch (err) {
        console.error('Failed to send shutdown command or delete lock file:', err);
    }
};

// Export execute function
module.exports.execute = stopPaperMC;
