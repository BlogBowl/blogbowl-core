import { useEffect, useRef } from "react";

if (typeof window !== 'undefined') {
    window.MonacoEnvironment = {
        getWorker: function (workerId, label) {
            if (label === 'html') {
                return new Worker('https://cdn.jsdelivr.net/npm/monaco-editor@0.50.0/esm/vs/language/html/html.worker.js', { type: 'module' });
            }
            // Add other language workers here if needed
            return new Worker('https://cdn.jsdelivr.net/npm/monaco-editor@0.50.0/esm/vs/editor/editor.worker.js', { type: 'module' });
        }
    };
}

const MonacoEditor = ({ initialValue, name }) => {
    const elementRef = useRef(null);
    const hiddenInputRef = useRef(null);
    const editorRef = useRef(null);


    useEffect(() => {
        Turbo.cache.exemptPageFromCache();
        (async () => {
            editorRef.current = (await import('https://cdn.jsdelivr.net/npm/monaco-editor@0.50.0/+esm')).editor.create(elementRef.current, {
                value: hiddenInputRef.current.value,
                language: 'html',
                theme: 'vs-light',
                automaticLayout: true,
                minimap: {enabled: false}, // Optionally disable minimap
                fontSize: 14, // Adjust as needed
                lineNumbers: 'on',
                roundedSelection: false,
                scrollBeyondLastLine: false,
                readOnly: false,
                wordWrap: 'on'
            });

            editorRef.current.onDidChangeModelContent(() => {
                hiddenInputRef.current.value = editorRef.current.getValue();
            });
        })();
    }, []);

    return (
        <>
            <div ref={elementRef} className='min-h-56'>
            </div>
            <input name={name} type='hidden' value={initialValue} ref={hiddenInputRef}/>
        </>
    );
}

export default MonacoEditor;
