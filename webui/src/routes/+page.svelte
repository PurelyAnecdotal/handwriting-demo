<script lang="ts">
    import { onMount } from 'svelte';

    let canvas: HTMLCanvasElement;
    let ctx: CanvasRenderingContext2D;
    let drawing = false;
    let prediction: string;
    let predicting = false;

    function startDrawing(event: MouseEvent) {
        drawing = true;
        draw(event);
    }

    function stopDrawing() {
        drawing = false;
        ctx.beginPath();
    }

    function draw(event: MouseEvent) {
        if (!drawing) return;

        ctx.lineWidth = 30;
        ctx.lineCap = 'round';
        ctx.strokeStyle = 'white';

        ctx.lineTo(
            event.clientX - canvas.offsetLeft,
            event.clientY - canvas.offsetTop
        );
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(
            event.clientX - canvas.offsetLeft,
            event.clientY - canvas.offsetTop
        );
    }

    function clearCanvas() {
        ctx.fillStyle = 'black';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctxSmall.fillStyle = 'black';
        ctxSmall.fillRect(0, 0, resizedCanvas.width, resizedCanvas.height);
    }

    async function predict() {
        predicting = true;

        ctxSmall.drawImage(canvas, 0, 0, 28, 28);

        const imageData = ctxSmall.getImageData(
            0,
            0,
            resizedCanvas.width,
            resizedCanvas.height
        );

        const data = imageData.data;

        console.log(data);

        const response = await fetch('/predict', {
            method: 'POST',
            body: data,
            headers: {
                'content-type': 'application/octet-stream'
            }
        });

        prediction = (await response.json()).prediction;

        predicting = false;
    }

    let resizedCanvas: HTMLCanvasElement;
    let ctxSmall: CanvasRenderingContext2D;

    onMount(() => {
        const context = canvas.getContext('2d');
        if (context) {
            ctx = context;
            ctx.fillStyle = 'black'; // Set fill color to black
            ctx.fillRect(0, 0, canvas.width, canvas.height); // Fill the canvas with black
        }

        const contextSmall = resizedCanvas.getContext('2d');
        if (contextSmall) {
            ctxSmall = contextSmall;
            ctxSmall.fillStyle = 'black';
            ctxSmall.fillRect(0, 0, resizedCanvas.width, resizedCanvas.height);
        }
        ctxSmall.imageSmoothingEnabled = false;
        ctx.imageSmoothingEnabled = false;
    });
</script>

<main class="font-sans p-4 w-fit">
    <canvas
        bind:this={canvas}
        onmousedown={startDrawing}
        onmouseup={stopDrawing}
        onmouseout={stopDrawing}
        onblur={stopDrawing}
        onmousemove={draw}
        width="280"
        height="280"
    ></canvas>
    <div class="my-2 w-full flex justify-between gap-2">
        <button onclick={clearCanvas} class="bg-slate-200 p-2 rounded w-full"
            >Clear</button
        >
        <button
            onclick={predict}
            disabled={predicting}
            class="bg-green-200 p-2 rounded w-full">Predict</button
        >
    </div>
    Preview:

    <canvas bind:this={resizedCanvas} width="28" height="28" class="resized"
    ></canvas>
    <div class="text-lg m-4">
        {#if predicting}
            Predicting
        {:else if prediction}
            Prediction: {prediction}
        {/if}
    </div>
</main>

<style>
    canvas {
        border: 1px solid black;
        cursor: crosshair;
        image-rendering: pixelated;
        image-rendering: crisp-edges;
    }

    canvas.resized {
        width: 280px;
        height: 280px;
    }
</style>
