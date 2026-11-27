import test from 'node:test';
import assert from 'node:assert/strict';
import {PlayerMedia} from '../../assets/js/player_media.js';

function fixture() {
  const classes = new Set();
  const state = {image: null};
  const hook = {...PlayerMedia, el: {
    querySelector: () => state.image,
    classList: {toggle(name, on) { on ? classes.add(name) : classes.delete(name); }, remove(name) { classes.delete(name); }},
  }};
  return {hook, classes, state};
}
function image(complete = false, width = 0) {
  return Object.assign(new EventTarget(), {complete, naturalWidth: width});
}

test('missing and failed images keep the fallback, successful images reveal the photo', () => {
  const {hook, classes, state} = fixture();
  hook.mounted();
  assert.equal(classes.has('media-ready'), false);
  state.image = image();
  hook.updated();
  state.image.dispatchEvent(new Event('error'));
  assert.equal(classes.has('media-ready'), false);
  state.image.naturalWidth = 128;
  state.image.dispatchEvent(new Event('load'));
  assert.equal(classes.has('media-ready'), true);
  hook.destroyed();
  state.image.dispatchEvent(new Event('error'));
  assert.equal(classes.has('media-ready'), true);
});

test('LiveView patches handle cached images and detach listeners from replaced images', () => {
  const {hook, classes, state} = fixture();
  state.image = image(true, 128);
  hook.mounted();
  assert.equal(classes.has('media-ready'), true);
  const previous = state.image;
  state.image = image(true, 64);
  hook.updated();
  previous.dispatchEvent(new Event('error'));
  assert.equal(classes.has('media-ready'), true);
  state.image.dispatchEvent(new Event('error'));
  assert.equal(classes.has('media-ready'), false);
  state.image = null;
  hook.updated();
  assert.equal(classes.has('media-ready'), false);
});
