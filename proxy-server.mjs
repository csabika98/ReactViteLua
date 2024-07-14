import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { spawn } from 'child_process';
import path from 'path';
import process from 'process';
import { fileURLToPath } from 'url';
import fs from 'fs';

const app = express();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function findProjectRoot(currentDir, targetFolderName) {
    const root = path.parse(currentDir).root;
    while (currentDir !== root) {
        let possiblePath = path.join(currentDir, targetFolderName);
        if (fs.existsSync(possiblePath)) {
            return currentDir; 
        }
        currentDir = path.dirname(currentDir);
    }
    return null; 
}

const projectRoot = findProjectRoot(__dirname, 'ReactViteLua');
const LuaProjectPath = path.join(projectRoot, 'ReactViteLua');
console.log(`RUN Lua project at path: ${LuaProjectPath}`);

let LuaProcess;

const runLuaApp = () => {
    if (LuaProcess) {
        console.log('Stopping existing Lua application...');
        LuaProcess.kill();
        LuaProcess = null;
    }
    console.log('Starting Lua application...');
    console.log('Executing command: lapis server');

    const isWSL = process.env.WSL_DISTRO_NAME !== undefined;
    const command = isWSL ? 'wsl' : './run_lua.sh';
    const args = isWSL ? ['./run_lua.sh'] : [];
    const options = { cwd: LuaProjectPath };

    LuaProcess = spawn(command, args, options);

    LuaProcess.stdout.on('data', (data) => console.log(`Lua: ${data}`));
    LuaProcess.stderr.on('data', (data) => console.error(`Lua : ${data}`));
    LuaProcess.on('close', (code) => {
        console.log(`Lua process exited with code ${code}`);
    });
};

runLuaApp();
app.use((req, res, next) => {
    console.log(`Request received: ${req.method} ${req.url}`);
    next();
});

app.use('/api/', createProxyMiddleware({
    target: 'http://localhost:8081/',
    changeOrigin: true,
    ws: true
}));

app.use('/', createProxyMiddleware({
    target: 'http://localhost:5173/',
    changeOrigin: true,
    ws: false
}));

const PORT = 8888;
app.listen(PORT, () => {
    console.log(`Proxy server running on http://localhost:${PORT}`);
});

process.on('exit', () => {
    if (LuaProcess) {
        console.log('Stopping Lua application due to script exit...');
        LuaProcess.kill();
    }
});
