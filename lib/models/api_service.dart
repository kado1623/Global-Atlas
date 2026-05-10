import { ApiException } from "./api_exception";
import { Country, CountrySummary } from "../models/Country";

const _baseUrl = "https://restcountries.com/v3.1";
const _timeout = 10000;
const _headers: Record<string, string> = {
  "Content-Type": "application/json",
  Accept: "application/json",
};

async function _fetchWithTimeout(
  url: string,
  options: RequestInit = {}
): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), _timeout);
  try {
    const response = await fetch(url, {
      ...options,
      headers: { ..._headers, ...(options.headers || {}) },
      signal: controller.signal,
    });
    return response;
  } finally {
    clearTimeout(timer);
  }
}

function _checkResponse(response: Response): void {
  if (response.status !== 200) {
    throw new ApiException(
      response.status,
      `Server returned status ${response.status}: ${response.statusText}`
    );
  }
}

export async function fetchAllCountries(): Promise<CountrySummary[]> {
  const url = new URL(
    `${_baseUrl}/all?fields=name,flags,cca3,region,population`
  );
  const response = await _fetchWithTimeout(url.toString());
  _checkResponse(response);
  const json = await response.json();
  if (!Array.isArray(json)) {
    throw new TypeError("Unexpected data format received");
  }
  return json.map(CountrySummary.fromJson);
}

export async function searchByName(name: string): Promise<CountrySummary[]> {
  const url = new URL(`${_baseUrl}/name/${encodeURIComponent(name)}`);
  const response = await _fetchWithTimeout(url.toString());
  if (response.status === 404) {
    return [];
  }
  _checkResponse(response);
  const json = await response.json();
  if (!Array.isArray(json)) {
    throw new TypeError("Unexpected data format received");
  }
  return json.map(CountrySummary.fromJson);
}

export async function fetchByCode(code: string): Promise<Country> {
  const url = new URL(`${_baseUrl}/alpha/${encodeURIComponent(code)}`);
  const response = await _fetchWithTimeout(url.toString());
  _checkResponse(response);
  const json = await response.json();
  const arr = Array.isArray(json) ? json : [json];
  if (!arr[0]) {
    throw new ApiException(404, "Country not found");
  }
  return Country.fromJson(arr[0]);
}
