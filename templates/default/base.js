const dark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

const prismStyle = document.createElement('link');
prismStyle.rel = 'stylesheet';

if(dark) {
    prismStyle.href = 'https://cdn.l7ssha.xyz/atom-one-dark.css';
} else {
    prismStyle.href = 'https://cdn.l7ssha.xyz/atom-one-light.css';
}

document.head.appendChild(prismStyle);

document.addEventListener('DOMContentLoaded', (event) => {
    hljs.highlightAll();
});
