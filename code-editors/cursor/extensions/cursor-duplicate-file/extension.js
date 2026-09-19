const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

function activate(context) {
    let disposable = vscode.commands.registerCommand('cursor-duplicate-file.duplicate', async () => {
        const activeEditor = vscode.window.activeTextEditor;
        if (!activeEditor) return;

        const currentFilePath = activeEditor.document.uri.fsPath;
        if (!fs.existsSync(currentFilePath)) return;

        const dir = path.dirname(currentFilePath);
        const ext = path.extname(currentFilePath);
        const baseName = path.basename(currentFilePath, ext);

        let newFileName = `${baseName}_copy${ext}`;
        let newFilePath = path.join(dir, newFileName);

        let counter = 1;
        while (fs.existsSync(newFilePath)) {
            newFileName = `${baseName}_copy_${counter}${ext}`;
            newFilePath = path.join(dir, newFileName);
            counter++;
        }

        try {
            fs.copyFileSync(currentFilePath, newFilePath);
            const newDocument = await vscode.workspace.openTextDocument(newFilePath);
            await vscode.window.showTextDocument(newDocument);
        } catch (err) {
            vscode.window.showErrorMessage(err.message);
        }
    });

    context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = { activate, deactivate };
