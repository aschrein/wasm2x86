Module.onRuntimeInitialized = function(){ 
  let ENVIRONMENT_IS_WEB = typeof window === 'object';
  if (!ENVIRONMENT_IS_WEB)
    return;

    var style = document.createElement('style');
  style.innerHTML = `
  canvas {
    margin: 0%;
    image-rendering: optimizeSpeed;             /* Older versions of FF          */
    image-rendering: -moz-crisp-edges;          /* FF 6.0+                       */
    image-rendering: -webkit-optimize-contrast; /* Safari                        */
    image-rendering: -o-crisp-edges;            /* OS X & Windows Opera (12.02+) */
    image-rendering: pixelated;                 /* Awesome future-browsers       */
    -ms-interpolation-mode: nearest-neighbor;   /* IE                            */
    }
  `;
  document.head.appendChild(style);
   
    const width = 512, height = 512;
    const outputPtr = Module._malloc(width*height*4); // And writes to a 8-bit RGBA image buffer.

    Module._run(outputPtr);

    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    const id = ctx.createImageData(width, height);
    // console.log(outputPtr + " " +  width*height*4);
    let uint8array = new Uint8Array(Module.asm.memory.buffer, outputPtr, width*height*4);
    
    // console.log(uint8array);
    // for (let i = 0, j = 0; i < uint8array.length; i += 4, j += 4) {
    //   let r = uint8array[i];
    //   let g = uint8array[i + 1];
    //   let b = uint8array[i + 2];
    //   id.data[j + 0] = r;  // R value
    //   id.data[j + 1] = g;    // G value
    //   id.data[j + 2] = b;  // B value
    //   id.data[j + 3] = 255;  // A value
    // }
    id.data.set(uint8array, 0);
    ctx.putImageData(id, 0, 0);
    document.body.append(canvas);
};