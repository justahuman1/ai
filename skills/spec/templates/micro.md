# Micro Spec Template

Ultra-lightweight template for changes under 1 day of effort — bug fixes, copy changes, minor tweaks.

---

# [Brief Change Description]

**Type:** [Bug Fix/Copy Change/Config Update/Minor Feature]
**Effort:** [X hours]
**Date:** [YYYY-MM-DD]

## What
[One sentence describing the change]

## Why
[Brief justification — why is this needed?]

## How
- [ ] [Implementation step 1]
- [ ] [Implementation step 2]
- [ ] [Implementation step 3]

## Acceptance
[Simple pass/fail criteria — how do you know it worked?]

## Files
- `[file/path]` — [what changes]

---

## Examples

### Bug Fix Example
# Fix Login Button Alignment

**Type:** Bug Fix
**Effort:** 2 hours
**Date:** 2024-01-15

## What
Fix login button that's misaligned on mobile devices

## Why
Button is partially cut off on screens smaller than 375px, preventing users from logging in

## How
- [ ] Update CSS media query in `login.css` to use `flex-direction: column` for small screens
- [ ] Adjust button margin from `10px` to `5px` for mobile
- [ ] Test on iPhone SE and Android small screens

## Acceptance
Login button is fully visible and clickable on all screen sizes 375px and above

## Files
- `styles/login.css` — Update mobile media query

---

### Minor Feature Example
# Add Loading Spinner to Save Button

**Type:** Minor Feature
**Effort:** 3 hours
**Date:** 2024-01-15

## What
Show loading spinner on save button while form is submitting

## Why
Users are clicking save multiple times because they don't know if it's working

## How
- [ ] Add loading state to save button component
- [ ] Show spinner icon and disable button during API call
- [ ] Reset state when save completes or fails

## Acceptance
Save button shows spinner and is disabled during form submission, returns to normal when complete

## Files
- `components/SaveButton.jsx` — Add loading state logic

---

## Quick Checklists

### Before Starting
- [ ] Change is clearly defined
- [ ] Effort estimate is under 1 day
- [ ] No dependencies on other work
- [ ] Success criteria are obvious

### Before Completing
- [ ] Acceptance criteria met
- [ ] Code reviewed (if required)
- [ ] Change deployed/merged
