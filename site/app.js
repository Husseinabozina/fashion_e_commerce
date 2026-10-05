"use strict";
const screens = {
  home: {
    title: "Home",
    alt: "NOVA home — Drop 026, new arrivals and navigation",
  },
  discover: {
    title: "Discover",
    alt: "Dark Discover screen — editorial collection and featured pieces",
  },
  bag: {
    title: "Your bag",
    alt: "Shopping bag — three products, quantities, promo code and EGP totals",
  },
  account: {
    title: "Account",
    alt: "Guest account — sign-in, orders, saved items and preferences",
  },
  confirmation: {
    title: "Demo order confirmation",
    alt: "Demo order placed — reference, total and order navigation",
  },
};
const tabs = [...document.querySelectorAll('[role="tab"]')];
const panel = document.getElementById("screen-panel");
const activeImage = document.getElementById("active-screen");
const zoom = document.querySelector(".screen-zoom");
const dialog = document.getElementById("screenshot-dialog");
let selected = "home";
function selectScreen(tab) {
  selected = tab.dataset.screen;
  tabs.forEach((item) => {
    const active = item === tab;
    item.classList.toggle("active", active);
    item.setAttribute("aria-selected", String(active));
    item.tabIndex = active ? 0 : -1;
  });
  activeImage.src = `assets/screens/${selected}.png`;
  activeImage.alt = screens[selected].alt;
  panel.setAttribute("aria-labelledby", tab.id);
  panel.querySelector(".screen-index").textContent = String(
    tabs.indexOf(tab) + 1,
  ).padStart(2, "0");
  zoom.setAttribute(
    "aria-label",
    `Enlarge ${screens[selected].title} screenshot`,
  );
}
tabs.forEach((tab, index) => {
  tab.addEventListener("click", () => selectScreen(tab));
  tab.addEventListener("keydown", (event) => {
    let target;
    if (event.key === "ArrowDown" || event.key === "ArrowRight")
      target = (index + 1) % tabs.length;
    if (event.key === "ArrowUp" || event.key === "ArrowLeft")
      target = (index - 1 + tabs.length) % tabs.length;
    if (event.key === "Home") target = 0;
    if (event.key === "End") target = tabs.length - 1;
    if (target !== undefined) {
      event.preventDefault();
      tabs[target].focus();
      selectScreen(tabs[target]);
    }
  });
});
zoom.addEventListener("click", () => {
  document.getElementById("dialog-title").textContent =
    `NOVA — ${screens[selected].title}`;
  const image = document.getElementById("dialog-image");
  image.src = activeImage.src;
  image.alt = activeImage.alt;
  document.getElementById("original-link").href = activeImage.src;
  dialog.showModal();
  document.body.style.overflow = "hidden";
});
document
  .getElementById("close-dialog")
  .addEventListener("click", () => dialog.close());
dialog.addEventListener("click", (event) => {
  if (event.target === dialog) {
    const r = dialog.getBoundingClientRect();
    if (
      event.clientX < r.left ||
      event.clientX > r.right ||
      event.clientY < r.top ||
      event.clientY > r.bottom
    )
      dialog.close();
  }
});
dialog.addEventListener("close", () => {
  document.body.style.overflow = "";
  zoom.focus();
});

const galleryMedia = window.matchMedia("(max-width: 760px)");
function orientGallery() {
  document
    .querySelector("[role=tablist]")
    .setAttribute(
      "aria-orientation",
      galleryMedia.matches ? "horizontal" : "vertical",
    );
}
galleryMedia.addEventListener("change", orientGallery);
orientGallery();
