export function emit(
  step: number,
  total: number,
  stage: string,
  message: string,
  ok?: boolean | null
): void {
  const prefix = ok === true ? "✅" : ok === false ? "❌" : "⏳";
  console.log(`${prefix} [${step}/${total}] ${stage} - ${message}`);
}
